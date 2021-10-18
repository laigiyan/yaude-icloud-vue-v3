<template>
  <a-card :bordered="false">
    <!-- 查询区域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="网络名称">
              <a-input placeholder="请输入网络名称" v-model="queryParam.networkName"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查询</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
              <a @click="handleToggleSearch" style="margin-left: 8px">
                {{ toggleSearchStatus ? '收起' : '展开' }}
                <a-icon :type="toggleSearchStatus ? 'up' : 'down'"/>
              </a>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查询区域-END -->

    <!-- 操作按钮区域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">申请</a-button>
      <a-button @click="handleAdjust" type="primary" icon="plus">调整</a-button>
      <a-button @click="handleSubmit" type="primary" icon="plus">提交</a-button>
    <!--  <a-button type="primary" icon="download" @click="handleExportXls('浮动ip申请明细档')">导出</a-button>
      <a-upload name="file" :showUploadList="false" :multiple="false" :headers="tokenHeader" :action="importExcelUrl" @change="handleImportExcel">
        <a-button type="primary" icon="import">导入</a-button>
      </a-upload>-->
      <!-- 高级查询区域 -->
    <!--  <j-super-query :fieldList="superFieldList" ref="superQueryModal" @handleSuperQuery="handleSuperQuery"></j-super-query>-->
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
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange}"
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

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">编辑</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
              <a-menu-item>
                <a @click="handleDetail(record)">详情</a>
              </a-menu-item>
              <a-menu-item>
                <a-popconfirm title="确定删除吗?" @confirm="() => handleDelete(record.id)">
                  <a>删除</a>
                </a-popconfirm>
              </a-menu-item>
            </a-menu>
          </a-dropdown>
        </span>

      </a-table>
    </div>

    <os-apply-floatip-modal ref="modalForm" @ok="modalFormOk"></os-apply-floatip-modal>
    <os-floatip-adjust-modal ref="adjustModal" @ok="modalFormOk"></os-floatip-adjust-modal>>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import { httpAction, getAction } from '@/api/manage'
  import OsApplyFloatipModal from './modules/OsApplyFloatipModal'
  import OsFloatipAdjustModal from './modules/OsFloatipAdjustModal'

  export default {
    name: 'OsApplyFloatipList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      OsApplyFloatipModal,
      OsFloatipAdjustModal
    },
    data () {
      return {
        description: '浮动ip申请明细档管理页面',
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
            title:'网络名称',
            align:"center",
            dataIndex: 'networkName'
          },
          {
            title:'申請类型',
            align:"center",
            dataIndex: 'options_dictText'
          },
          {
            title:'申请狀態',
            align:"center",
            dataIndex: 'status_dictText'
          },
          {
            title:'子网名称',
            align:"center",
            dataIndex: 'subnetName'
          },
          {
            title:'浮动ip',
            align:"center",
            dataIndex: 'floatIp'
          },

          {
            title:'申请时间',
            align:"center",
            dataIndex: 'startTime'
            /*customRender:function (text) {
              return !text?"":(text.length>10?text.substr(0,10):text)
            }*/
          },
          {
            title:'终止时间',
            align:"center",
            dataIndex: 'endTime'
          },
          {
            title:'所屬項目',
            align:"center",
            dataIndex: 'projectName'
          },
          {
            title:'映射vm_ip',
            align:"center",
            dataIndex: 'mapperIp'
          },
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
          list: "/os/osApplyFloatip/list",
          delete: "/os/osApplyFloatip/delete",
          deleteBatch: "/os/osApplyFloatip/deleteBatch",
          exportXlsUrl: "/os/osApplyFloatip/exportXls",
          importExcelUrl: "os/osApplyFloatip/importExcel",
          submit: "os/osApplyFloatip/submit",
        },
        dictOptions:{},
        superFieldList:[],
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
      handleAdjust(){
        const that = this;
        var params = this.selectionRows[0] ;
        if (this.selectedRowKeys.length <= 0) {
          this.$message.warning('请选择一条记录！');
          return false;
        }else{
          this.$refs.adjustModal.adjust(params);
        }
      },
      handleSubmit(){
        var params = this.selectionRows[0] ;
        if (this.selectedRowKeys.length <= 0) {
          this.$message.warning('请选择一条记录！');
          return false;
        }else if(params.status!=null){
          this.$message.warning('该记录已申请！');
        }else{
          const that = this;
          let method = "put";
          let httpurl = this.url.submit;
          httpAction(httpurl,params,method).then((res)=>{
            if(res.success){
              that.$message.success(res.message);
              that.$emit('ok');
              that.loadData();
            }else{
              that.$message.warning(res.message);
            }
          })
        }
      },
      modalFormOk(){
        this.$nextTick(()=>{
          this.loadData();
        })
      },
      getSuperFieldList(){
        let fieldList=[];
        fieldList.push({type:'string',value:'networkName',text:'网络名称',dictCode:''})
        fieldList.push({type:'string',value:'subnetName',text:'子网名称',dictCode:''})
        fieldList.push({type:'string',value:'floatIp',text:'浮动ip',dictCode:''})
        fieldList.push({type:'string',value:'options',text:'申請类型',dictCode:''})
        fieldList.push({type:'string',value:'status',text:'申请狀態',dictCode:''})
        fieldList.push({type:'string',value:'represent',text:'描述',dictCode:''})
        fieldList.push({type:'date',value:'startTime',text:'申请时间'})
        fieldList.push({type:'string',value:'mapperIp',text:'映射vm_ip',dictCode:''})
        this.superFieldList = fieldList
      }
    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>