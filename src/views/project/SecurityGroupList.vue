<template>
  <a-card :bordered="false">
    <!-- 查詢區域 -->
    <div class="table-page-search-wrapper">
      <a-form layout="inline" @keyup.enter.native="searchQuery">
        <a-row :gutter="24">
          <a-col :xl="6" :lg="7" :md="8" :sm="24" >
            <a-form-model-item label="項目名稱"  >
              <a-select v-model="queryParam.projectId"  placeholder="請選擇項目" >
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <a-form-item label="安全組名稱">
              <a-input placeholder="請輸入安全組名稱" v-model="queryParam.name"></a-input>
            </a-form-item>
          </a-col>
          <a-col :xl="6" :lg="7" :md="8" :sm="24">
            <span style="float: left;overflow: hidden;" class="table-page-search-submitButtons">
              <a-button type="primary" @click="searchQuery" icon="search">查詢</a-button>
              <a-button type="primary" @click="searchReset" icon="reload" style="margin-left: 8px">重置</a-button>
            </span>
          </a-col>
        </a-row>
      </a-form>
    </div>
    <!-- 查詢區域-END -->

    <!-- 操作按鈕區域 -->
    <div class="table-operator">
      <a-button @click="handleAdd" type="primary" icon="plus">新增</a-button>

      <!--<a-dropdown v-if="selectedRowKeys.length > 0">
        <a-menu slot="overlay">
          <a-menu-item key="1" @click="batchDel"><a-icon type="delete"/>刪除</a-menu-item>
        </a-menu>
        <a-button style="margin-left: 8px"> 批量操作 <a-icon type="down" /></a-button>
      </a-dropdown>-->
    </div>

    <!-- table區域-begin -->
    <div>

      <a-table
        ref="table"
        size="middle"
        :scroll="{x:true}"
        bordered
        rowKey="securityGroupId"
        :columns="columns"
        :dataSource="dataSource"
        :pagination="ipagination"
        :loading="loading"
        :rowSelection="{selectedRowKeys: selectedRowKeys, onChange: onSelectChange,type:'radio'}"
        class="j-table-force-nowrap"
        @change="handleTableChange">

        <template slot="htmlSlot" slot-scope="text">
          <div v-html="text"></div>
        </template>
        <template slot="imgSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無圖片</span>
          <img v-else :src="getImgView(text)" height="25px" alt="" style="max-width:80px;font-size: 12px;font-style: italic;"/>
        </template>
        <template slot="fileSlot" slot-scope="text">
          <span v-if="!text" style="font-size: 12px;font-style: italic;">無文件</span>
          <a-button
            v-else
            :ghost="true"
            type="primary"
            icon="download"
            size="small"
            @click="downloadFile(text)">
            下載
          </a-button>
        </template>

        <span slot="projectName" slot-scope="text, record">
          <a @click="handleRouter(record)">{{ text }}</a>
        </span>

        <span slot="action" slot-scope="text, record">
          <a @click="handleEdit(record)">編輯</a>

          <a-divider type="vertical" />
          <a-dropdown>
            <a class="ant-dropdown-link">更多 <a-icon type="down" /></a>
            <a-menu slot="overlay">
                          <a-menu-item>
                            <a-popconfirm title="確定刪除嗎?" @confirm="() => handleDelete(record)">
                              <a>刪除</a>
                            </a-popconfirm>
                          </a-menu-item>
            </a-menu>


          </a-dropdown>
        </span>

      </a-table>
    </div>

    <a-tabs defaultActiveKey="1">
      <a-tab-pane tab="安全組規則" key="1">
        <security-group-rule-list :remote-group-ids="remoteGroupIds" ref="securityGroupRuleList"></security-group-rule-list>
      </a-tab-pane>
    </a-tabs>

    <security-group-modal ref="modalForm" @ok="modalFormOk"></security-group-modal>
  </a-card>
</template>

<script>

  import '@/assets/less/TableExpand.less'
  import { mixinDevice } from '@/utils/mixin'
  import { JeecgListMixin } from '@/mixins/JeecgListMixin'
  import SecurityGroupModal from './modules/SecurityGroupModal'
  import SecurityGroupRuleList from './SecurityGroupRuleList'
  import { httpAction,deleteAction, getAction,downFile,getFileAccessHttpUrl } from '@/api/manage'

  export default {
    name: 'SecurityGroupList',
    mixins:[JeecgListMixin, mixinDevice],
    components: {
      SecurityGroupModal,
      SecurityGroupRuleList
    },
    data () {
      return {
        description: '申請明細檔管理頁面',
        // 表頭
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
            title:'安全組名稱',
            align:"center",
            dataIndex: 'name',
          },
          {
            title:'安全組ID',
            align:"center",
            dataIndex: 'securityGroupId'
          },
          {
            title:'描述',
            align:"center",
            dataIndex: 'description'
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
          list: "/openstack/securityGroup/list",
          delete: "/openstack/securityGroup/deleteSecurityGroup",
          getProject: "/os/osApply/getProject",

        },
        dictOptions:{},
        superFieldList:[],
        multiUser:'',
        // 選擇用戶查詢條件配置
        selectUserQueryConfig: [
          {key: 'phone', label: '電話'},
        ],
        projects:[],
        remoteGroupIds:[],
      }
    },
    created() {
      this.getSuperFieldList();
      this.getProjects();
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
        fieldList.push({type:'string',value:'enbled',text:'啟用',dictCode:''})
        this.superFieldList = fieldList
      },
      handleAdd: function () {
        if(this.queryParam.projectId){
          this.$refs.modalForm.add({projectId:this.queryParam.projectId});
          this.$refs.modalForm.title = "新增";
          this.$refs.modalForm.disableSubmit = false;
        }else{
          this.$message.error("請選擇一個項目！")
        }

      },
      handleDelete: function (record) {
        if(!this.url.delete){
          this.$message.error("請設置url.delete屬性!")
          return
        }
        var that = this;
        getAction(that.url.delete, record).then((res) => {
          if (res.success) {
            //重新計算分頁問題
            that.reCalculatePage(1)
            that.$message.success(res.message);
            that.loadData();
          } else {
            that.$message.warning(res.message);
          }
        });
      },
      handleOK(){
        this.loadData(1)
      },
      getProjects(){
        let method = "post";
        debugger
        let httpurl = this.url.getProject;
        httpAction(httpurl, { },method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },
      onSelectChange(selectedRowKeys, selectionRows) {
        this.selectedRowKeys = selectedRowKeys;
        this.selectionRows = selectionRows;
        this.dataSource.forEach((r)=>{
          let name = r.name;
          if(r.securityGroupId == selectedRowKeys){
            name = name +"(當前)";
          }
          this.remoteGroupIds.push({
            value:r.securityGroupId,
            text:name,
          })
        })
        this.$refs.securityGroupRuleList.getRuleMain(this.selectionRows[0]);
      },

    }
  }
</script>
<style scoped>
  @import '~@assets/less/common.less';
</style>