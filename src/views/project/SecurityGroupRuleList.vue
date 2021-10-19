<template>
  <a-card :bordered="false">


    <!-- 操作按钮区域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>

      <a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>删除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>
    </div>

    <!-- table区域-begin -->
    <div>
      <div class="ant-alert ant-alert-info" style="margin-bottom: 16px;">
        <i class="anticon anticon-info-circle ant-alert-icon"></i> 已选择 <a style="font-weight: 600">{{ selectedRowKeys.length }}</a>项
        <a style="margin-left: 24px" @click="onClearSelected">清空</a>
      </div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="id"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys , onChange: onSelectChange}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无图片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">无文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下载
          </a-button>
        </template>

        <span slot="projectName" slot-scope="text, record">
          <a @click="handleRouter(record)">{{ text }}</a>
        </span>

        <span slot="action" slot-scope="text, record">
          <!--<a @click="handleEdit(record)">编辑</a>

          <a-divider type="vertical" />-->
          <a-menu-item>
                            <a-popconfirm title="确定删除吗?" @confirm="() => handleDelete(record)">
                              <a>删除</a>
                            </a-popconfirm>
                          </a-menu-item>
        </span>

      </a-table>
    </div>

    <security-group-rule-modal ref="modalForm" @ok="modalFormOk"></security-group-rule-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import { deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'
  import SecurityGroupRuleModal from './modules/SecurityGroupRuleModal'

  export default {
    name: 'SecurityGroupRuleList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      SecurityGroupRuleModal
    },
    data () {
      return {
        description: '安全組規則細檔管理页面',
        // 表头
        columns: [
          {
            title: '#',
            dataIndex: '',
            key:'rowIndex',
            width:60,
            align:"center",
            customRender:function (t,r,index) {
              return parseInt(index)+1;
            }
          },
          {
            title:'方向',
            align:"center",
            dataIndex: 'direction',
          },
          {
            title:'網絡類型',
            align:"center",
            dataIndex: 'ethertype',
          },
          {
            title:'IP協議',
            align:"center",
            dataIndex: 'protocol'
          },
          {
            title:'端口最小值',
            align:"center",
            dataIndex: 'portRange',
          },
          {
            title:'远程IP前缀',
            align:"center",
            dataIndex: 'remoteIpPrefix'
          },
          {
            title:'安全組ID',
            align:"center",
            dataIndex: 'remoteGroupId'
          },
          /*{
            title:'描述',
            align:"center",
            dataIndex: 'description'
          },*/
          {
            title: '操作',
            dataIndex: 'action',
            align:"center",
            fixed:"right",
            width:147,
            scopedSlots: { customRender: 'action' }
          }
        ],
        url: {
          list: "/openstack/securityGroup/listRules",
          delete: "/openstack/securityGroup/deleteSecurityGroupRule",

        },
        dictOptions:{},
        superFieldList:[],
        multiUser:'',
        // 选择用户查询条件配置
        selectUserQueryConfig: [
          {key: 'phone', label: '电话'},
        ],
      }
    },
    created() {
      this.getSuperFieldList();
    },
    computed: {
      importExcelUrl: function(){
        return `${window._CONFIG['domianURL']}/${this.url.importExcelUrl}`;
      },
    },
    methods: {
      initDictConfig(){
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'projectName',text:'項目名稱',dictCode:''})
        fieldList.push({type:'string',value:'description',text:'描述',dictCode:''})
        fieldList.push({type:'string',value:'projectId',text:'項目ID',dictCode:''})
        fieldList.push({type:'string',value:'domainName',text:'域名',dictCode:''})
        fieldList.push({type:'string',value:'enbled',text:'啓用',dictCode:''})
        this.superFieldList = fieldList
      },
      getRuleMain(record){
        this.queryParam.projectId = record.projectId;
        this.queryParam.securityGroupId = record.securityGroupId;
        this.queryParam.name = record.name;
        this.loadData(1)
      },
      handleAdd: function () {
        if(this.queryParam.projectId&& this.queryParam.securityGroupId){
          this.$refs.modalForm.add({projectId:this.queryParam.projectId,securityGroupId:this.queryParam.securityGroupId});
          this.$refs.modalForm.title = "新增";
          this.$refs.modalForm.disableSubmit = false;
        }else{
          this.$message.error("請選擇一个安全组！")
        }

      },
      handleDelete: function (record) {
        if(!this.url.delete){
          this.$message.error("请设置url.delete属性!")
          return
        }
        record.projectId = this.queryParam.projectId;
        var that = this;
        getAction(that.url.delete, record).then((res) => {
          if (res.success) {
            //重新计算分页问题
            that.reCalculatePage(1)
            that.$message.success(res.message);
            that.loadData();
          } else {
            that.$message.warning(res.message);
          }
        });
      },
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>